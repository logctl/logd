#include <errno.h>
#include <error.h>
#include <libgen.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "libuv/uv.h"
#include "luv/luv.h"
#include "luvi/lenv.c"
#include "luvi/lminiz.c"
#include "luvi/luvi.c"
#include "luvi/luvi.h"

#include "logd_module.h"
#include "lua.h"
#include "util.h"

int luaopen_rex_pcre(lua_State* L);
int luaopen_openssl(lua_State* L);
int luaopen_lpeg(lua_State* L);

static int lua_load_libs(lua_t* l, uv_loop_t* loop)
{
	luaopen_logd(l->state);

	if (luaopen_luv_loop(l->state, loop) < 0)
		return 1;

	/* preload all luvi builtins except:
	 *		- snapshot
	 *		- zlib
	 *		- init
	 */
	lua_getglobal(l->state, "package");
	lua_getfield(l->state, -1, "preload");
	lua_remove(l->state, -2);

	lua_pushcfunction(l->state, luaopen_env);
	lua_setfield(l->state, -2, "env");

	lua_pushcfunction(l->state, luaopen_miniz);
	lua_setfield(l->state, -2, "miniz");

	lua_pushcfunction(l->state, luaopen_lpeg);
	lua_setfield(l->state, -2, "lpeg");

	lua_pushcfunction(l->state, luaopen_rex_pcre);
	lua_setfield(l->state, -2, "rex");

	lua_pushcfunction(l->state, luaopen_luvi);
	lua_setfield(l->state, -2, "luvi");

	lua_pushcfunction(l->state, luaopen_openssl);
	lua_setfield(l->state, -2, "openssl");

	lua_pop(l->state, 1);

	return 0;
}

char* make_run_str(lua_State* state, const char* script)
{
	char* run_str = NULL;

	int want = snprintf(NULL, 0, "return require('init')('%s')", script);
	if ((run_str = malloc(want + 1)) == NULL) {
		perror("malloc");
		errno = ENOMEM;
		goto exit;
	}
	sprintf(run_str, "return require('init')('%s')", script);

exit:
	return run_str;
}

static void lua_push_on_error(lua_State* state)
{
	lua_getglobal(state, LUA_NAME_LOGD_MODULE);
	lua_getfield(state, -1, LUA_NAME_ON_ERROR);
}

static void lua_push_on_eof(lua_State* state)
{
	lua_getglobal(state, LUA_NAME_LOGD_MODULE);
	lua_getfield(state, -1, LUA_NAME_ON_EOF);
}

static void lua_push_on_log(lua_State* state)
{
	// TODO optimize by pre-loading
	lua_getglobal(state, LUA_NAME_LOGD_MODULE);
	lua_getfield(state, -1, LUA_NAME_ON_LOG);
}

lua_t* lua_create(uv_loop_t* loop, const char* script)
{
	lua_t* l = NULL;

	if ((l = calloc(1, sizeof(lua_t))) == NULL) {
		perror("calloc");
		goto error;
	}

	if (lua_init(l, loop, script) == -1) {
		goto error;
	}

	return l;

error:
	if (l)
		free(l);
	return NULL;
}

int lua_init(lua_t* l, uv_loop_t* loop, const char* script)
{
	char* run_str = NULL;
	int lerrno;

	l->state = luaL_newstate();
	l->loop = loop;

	luaL_openlibs(l->state);

	if (lua_load_libs(l, l->loop) != 0) {
		perror("lua_load_libs");
		goto error;
	}

	if ((run_str = make_run_str(l->state, script)) == NULL) {
		goto error;
	}

	/* Load the init.lua builtin script */
	if (luaL_dostring(l->state, run_str)) {
		fprintf(
		  stderr, "Couldn't load script: %s\n", lua_tostring(l->state, -1));
		errno = EINVAL;
		goto error;
	}

	lua_push_on_log(l->state);
	if (!lua_isfunction(l->state, -1)) {
		fprintf(stderr,
		  "Couldn not find '" LUA_NAME_LOGD_MODULE "." LUA_NAME_ON_LOG
		  "' function in loaded script\n");
		errno = EINVAL;
		goto error;
	}

	/* pop logd module and on_log from the stack */
	lua_pop(l->state, 2);

	return 0;

error:
	lerrno = errno;
	if (run_str)
		free(run_str);
	if (l->state)
		lua_close(l->state);
	errno = lerrno;
	return -1;
}

void lua_call_on_log(lua_t* l, log_t* log)
{
	lua_push_on_log(l->state);
	DEBUG_ASSERT(lua_isfunction(l->state, -1));

	lua_pushlightuserdata(l->state, log);

	lua_call(l->state, 1, 0);
	lua_pop(l->state, 1); // logd module
}

bool lua_on_error_defined(lua_t* l)
{
	bool ret;

	lua_push_on_error(l->state);
	ret = lua_isfunction(l->state, -1);
	lua_pop(l->state, 2);

	return ret;
}

void lua_call_on_error(
  lua_t* l, const char* err, log_t* partial, const char* at)
{
	lua_push_on_error(l->state);
	DEBUG_ASSERT(lua_isfunction(l->state, -1));

	lua_pushstring(l->state, err);
	lua_pushlightuserdata(l->state, partial);
	lua_pushstring(l->state, at);

	lua_call(l->state, 3, 0);
	lua_pop(l->state, 1); // logd module
}

bool lua_on_eof_defined(lua_t* l)
{
	bool ret;

	lua_push_on_eof(l->state);
	ret = lua_isfunction(l->state, -1);
	lua_pop(l->state, 2);

	return ret;
}

void lua_call_on_eof(lua_t* l)
{
	lua_push_on_eof(l->state);
	DEBUG_ASSERT(lua_isfunction(l->state, -1));

	lua_call(l->state, 0, 0);
	lua_pop(l->state, 1); // logd module
}

void lua_free(lua_t* l)
{
	if (l) {
		lua_close(l->state);
		free(l);
	}
}

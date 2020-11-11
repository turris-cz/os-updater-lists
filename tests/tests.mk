
.PHONY: lint
lint: $(LISTS_LUA)
	@echo " LUACHECK"
	$(Q)$(LUACHECK) --config tests/luacheck.config $^

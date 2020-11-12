TEST_VARIANTS := latest 63.1.2 63.0.3


.PHONY: check
check: lint test


.PHONY: lint
lint: $(LISTS_LUA)
	@echo " LUACHECK"
	$(Q)$(LUACHECK) --config tests/luacheck.config $^


.PHONY: test
test:

# We can't test bootstrap as it has to run with full privilege and we simulate
# only secure environment.
TEST_LUA := $(filter-out %bootstrap.lua,$(LISTS_LUA))
# Migration script has to be readable only by latest version and 61.1.5.
MIGRATE_LUA := $(filter %migrate3x.lua,$(TEST_LUA))
TEST_LUA := $(filter-out %migrate3x.lua,$(TEST_LUA))

define TEST

.PHONY: test-$(1)
test-$(1):

test: test-bare-$(1)
test-$(1): test-bare-$(1)
.PHONY: test-bare-$(1)
test-bare-$(1): $(TEST_LUA) $$(if $$(filter latest,$(1)),$(MIGRATE_LUA))
	@echo " TEST BARE  $(1)"
	$(Q)tests/updater_$(1).lua $$^

test: test-turris-$(1)
test-$(1): test-turris-$(1)
.PHONY: test-turris-$(1)
test-turris-$(1): $(TEST_LUA) $$(if $$(filter latest,$(1)),$(MIGRATE_LUA))
	@echo " TEST TURRIS  $(1)"
	$(Q)tests/updater_$(1).lua --turris $$^

# Package lists were not handled in any different way in Turris OS 4.0
ifneq ($(1),63.1.2)
ifneq ($(1),63.0.3)

test: test-pkglists-$(1)
test-$(1): test-pkglists-$(1)
.PHONY: test-pkglists-$(1)
test-pkglists-$(1): $(PKGLISTS_LUA)
	@echo " TEST PKGLISTS  $(1)"
	$(Q)tests/updater_$(1).lua --pkglist $$^

endif
endif

endef

$(foreach VARIANT,$(TEST_VARIANTS),$(eval $(call TEST,$(VARIANT))))


test: test-61.1.5
.PHONY: test-61.1.5
test-61.1.5: $(filter %/migrate3x.lua,$(LISTS_LUA))
	@echo " TEST MIGRATE"
	$(Q)tests/updater_61.1.5.lua $^

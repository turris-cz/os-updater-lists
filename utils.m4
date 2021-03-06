divert(-1)

# esyscmd variant that terminates execution if command exits with non-zero code
# Usage: eesyscmd(`CMD')
define(`eesyscmd',`syscmd(`$1')ifelse(sysval,0,,`errprint(Command failed: $1)m4exit(`1')')')

# Transform lines in file to comma separated arguments
# Usage: file2args(`FILE')
define(`file2args',`syscmd(test -f $1)ifelse(sysval,0,,`errprint(File $1 is missing!)m4exit(`1')')dnl
esyscmd(`sed "/^#/d;s/\s//g;/^\s*\$/d" $1 | paste -sd "," | tr -d "\n"')')

# Expand second argument for all arguments after second one defined as macro
# with name of first argument.
# Usage: foreach(X,TEXT(X),a,b)
define(`foreach',`ifelse(eval($#>2),1,`pushdef(`$1',`$3')$2`'popdef(`$1')`'ifelse(eval($#>3),1,`$0(`$1',`$2',shift(shift(shift($@))))')')')

# Expand second argument for all arguments after third one defined as macro with
# name of fist argument. Every argument is then joined by third argument.
# Usage: foreach_join(X,TEXT(X),Y,a,b)
define(`foreach_join',`ifelse(eval($#>3),1,`pushdef(`$1',`$4')$2`'ifelse(eval($#>4),1,`$3')`'popdef(`$1')`'ifelse(eval($#>4),1,`$0(`$1',`$2',`$3',shift(shift(shift(shift($@)))))')')')

# Generate Install command with given PKGBASE and PKGPARTs joined: PKGBASE-PKGPART
# Usage: forInstall(PKGBASE, PKGPARTa, PKGPARTb)
define(`forInstall',`Install(foreach_join(PKGPART,`"$1-PKGPART"',`, ',shift($@)), { priority = 40 })')
define(`forInstallCritical',`Install(foreach_join(PKGPART,`"$1-PKGPART"',`, ',shift($@)), { critical = true })')

# Feature guard
# Some packages might not be installable without some features. Skipping every
# additional packages ensures that at least updater is updated.
define(`_FEATURE_GUARD_', `if features.request_condition then -- Advanced dependencies guard')
define(`_END_FEATURE_GUARD_', `end')
# This is empty for now because minimal version check is enought for now but is left there for future reuse.

divert(0)dnl
dnl We have minimal updater-ng version requirements
if not version_match or not self_version or version_match(self_version, "<60.0.1") then
	DIE("Minimal required version of Updater-ng for Turris repository is 60.0.1!")
end

if not board then
	local model = model or os_release["OPENWRT_DEVICE_PRODUCT"] or os_release["LEDE_DEVICE_PRODUCT"]
	if model:match("[Mm]ox") then
		board = "mox"
	elseif model:match("[Oo]mnia") then
		board = "omnia"
	elseif model:match("^[Tt]urris$") or model:match("[Tt]urris ?1%.?x") then
		board = "turris1x"
	else
		DIE("Unsupported Turris model: " .. tostring(model))
	end
end

-- Script simplifying lists inclusion when older version of updater is used
function list_script(list)
	if features["relative_uri"] then
		Script(list)
	else
		Script((repo_base_uri or "https://repo.turris.cz/hbs") .. "/" .. board .. "/lists/" .. list)
	end
end

-- Our own version of for_l10n to override priority and use condition
function for_l10n(fragment, condition)
	for _, lang in pairs(l10n or {}) do
		Install(fragment .. lang, {
			optional = true,
			priority = 10,
			condition = condition
		})
	end
end
----------------------------------------------------------------------------------

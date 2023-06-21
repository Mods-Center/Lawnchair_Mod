REPLACE="
/system/priv-app/MILauncher
/system/priv-app/MiLauncher
/system/priv-app/MILauncherGlobal
/system/priv-app/MiLauncherGlobal
/system/priv-app/MiuiHome
/system/priv-app/MIUIHome
/system/priv-app/MiuiLauncherGlobal
/system/priv-app/MIUILauncherGlobal
/system/product/priv-app/MILauncher
/system/product/priv-app/MiLauncher
/system/product/priv-app/MILauncherGlobal
/system/product/priv-app/MiLauncherGlobal
/system/product/priv-app/MiuiHome
/system/product/priv-app/MIUIHome
/system/product/priv-app/MiuiLauncherGlobal
/system/product/priv-app/MIUILauncherGlobal
"

SKIPUNZIP=1
SKIPMOUNT=false

install_files() {
    . $MODPATH/addon/install.sh

ui_print " "
ui_print " Warning: A13 is not supported."
ui_print " "
ui_print " "
ui_print "Let's start"
ui_print "Choose your Rom Version:"
ui_print "  Vol+ = Miui"
ui_print "  Vol- = Aosp"
ui_print " "

if chooseport; then
    ui_print "- Miui selected"
    cp -rf $MODPATH/files/launchermiui/MiuiHome.apk $MODPATH/system/priv-app/aMiuiHome
    cp -rf $MODPATH/files/miuioverlay/QuickSwitchOverlay.apk $MODPATH/system/product/overlay
else
{
    ui_print "- Aosp selected"
    cp -rf $MODPATH/files/launcheraosp/Lawnchair.apk $MODPATH/system/priv-app/Lawnchair
    cp -rf $MODPATH/files/aospoverlay/QuickSwitchOverlay.apk $MODPATH/system/product/overlay
}
fi

}

cleanup() {
	rm -rf $MODPATH/addon 2>/dev/null
	rm -rf $MODPATH/files 2>/dev/null
	rm -f $MODPATH/install.sh 2>/dev/null
	ui_print "- Deleting package cache files"
    rm -rf /data/resource-cache/*
    rm -rf /data/system/package_cache/*
    rm -rf /cache/*
    rm -rf /data/dalvik-cache/*
    ui_print "- Launcher updates will be uninstalled..."
    pm uninstall-system-updates com.miui.home
    pm uninstall-system-updates app.lawnchair
    ui_print "- Deleting old module (if it is installed)"
    touch /data/adb/modules/lawnchair_launcher_mod/remove
}

set_permissions() {
	#
    # Credit goes to the Magisk Module Template Extended by Zackptg5
    #
    # https://github.com/Zackptg5/MMT-Extended/blob/master/common/functions.sh#L226
    #
	set_perm_recursive $MODPATH 0 0 0755 0644
	if [ -d $MODPATH/system/vendor ]; then
		set_perm_recursive $MODPATH/system/vendor 0 0 0755 0644 u:object_r:vendor_file:s0
		[ -d $MODPATH/system/vendor/app ] && set_perm_recursive $MODPATH/system/vendor/app 0 0 0755 0644 u:object_r:vendor_app_file:s0
		[ -d $MODPATH/system/vendor/etc ] && set_perm_recursive $MODPATH/system/vendor/etc 0 0 0755 0644 u:object_r:vendor_configs_file:s0
		[ -d $MODPATH/system/vendor/overlay ] && set_perm_recursive $MODPATH/system/vendor/overlay 0 0 0755 0644 u:object_r:vendor_overlay_file:s0
		for FILE in $(find $MODPATH/system/vendor -type f -name *".apk"); do
			[ -f $FILE ] && chcon u:object_r:vendor_app_file:s0 $FILE
		done
	fi
}

run_install() {
	ui_print " "
	unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2
	ui_print " "
	ui_print "- Installing files"
	install_files
	sleep 1
	ui_print " "
	ui_print "- Cleaning up"
	ui_print " "
	cleanup
	sleep 1
	ui_print " "
	ui_print "- Setting Permissions"
	set_permissions
	sleep 1
	ui_print " "
	ui_print "- Removing any Launcher folder to avoid issues"
}

run_install

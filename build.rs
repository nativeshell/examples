use nativeshell_build::{AppBundleOptions, BuildResult, Flutter, FlutterOptions, MacOSBundle};

fn build_flutter() -> BuildResult<()> {
    Flutter::build(FlutterOptions {
        ..Default::default()
    })?;

    if cfg!(target_os = "macos") {
        let options = AppBundleOptions {
            bundle_name: "NativeShellExamples.app".into(),
            bundle_display_name: "NativeShell Examples".into(),
            icon_file: "icons/AppIcon.icns".into(),
            ..Default::default()
        };
        let resources = MacOSBundle::build(options)?;
        resources.mkdir("icons")?;
        resources.link("resources/mac_icon.icns", "icons/AppIcon.icns")?;
    }

    Ok(())
}

fn main() {
    if let Err(error) = build_flutter() {
        println!("Build failed with error:\n{}", error);
        panic!();
    }

    // Windows symbols used for file_open_dialog example
    #[cfg(target_os = "windows")]
    {
        windows::build!(
            Windows::Win32::System::SystemServices::{
                TRUE
            },
            Windows::Win32::UI::WindowsAndMessaging::{
                GetOpenFileNameW,
            }
        )
    }
}

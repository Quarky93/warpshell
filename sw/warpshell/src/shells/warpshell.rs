pub trait Warpshell {
    fn init(&self);
    // pub fn print_info();
    fn load_raw_user_image(&self, image: &[u8]);
}

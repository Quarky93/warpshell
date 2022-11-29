pub trait Readable {
    fn read(&self, buf: &mut [u8], offset: u64);

    fn read_u32(&self, offset: u64) -> u32 {
        let mut buf: [u8; 4] = [0; 4];
        self.read(&mut buf, offset);
        u32::from_le_bytes(buf)
    }

    fn read_u64(&self, offset: u64) -> u64 {
        let mut buf: [u8; 8] = [0; 8];
        self.read(&mut buf, offset);
        u64::from_le_bytes(buf)
    }

    fn read_u128(&self, offset: u64) -> u128 {
        let mut buf: [u8; 16] = [0; 16];
        self.read(&mut buf, offset);
        u128::from_le_bytes(buf)
    }
}

pub trait Writable {
    fn write(&self, buf: &[u8], offset: u64);

    fn write_u32(&self, data: u32, offset: u64) {
        self.write(&data.to_le_bytes(), offset)
    }

    fn write_u64(&self, data: u64, offset: u64) {
        self.write(&data.to_le_bytes(), offset)
    }

    fn write_u128(&self, data: u128, offset: u64) {
        self.write(&data.to_le_bytes(), offset)
    }
}

pub trait  ReadWritable: Readable + Writable {}

pub struct ReadableAddressSpace<'a> {
    channel: &'a dyn Readable,
    baseaddr: u64
}

pub struct WritableAddressSpace<'a> {
    channel: &'a dyn Writable,
    baseaddr: u64
}

pub struct ReadWritableAddressSpace<'a> {
    pub channel: &'a dyn ReadWritable,
    pub baseaddr: u64
}

impl Readable for ReadableAddressSpace<'_> {
    fn read(&self, buf: &mut [u8], offset: u64) {
        self.channel.read(buf, self.baseaddr + offset);
    }
}

impl Writable for WritableAddressSpace<'_> {
    fn write(&self, buf: &[u8], offset: u64) {
        self.channel.write(buf, self.baseaddr + offset);
    }
}

impl Readable for ReadWritableAddressSpace<'_> {
    fn read(&self, buf: &mut [u8], offset: u64) {
        self.channel.read(buf, self.baseaddr + offset);
    }
}

impl Writable for ReadWritableAddressSpace<'_> {
    fn write(&self, buf: &[u8], offset: u64) {
        self.channel.write(buf, self.baseaddr + offset);
    }
}

impl ReadWritable for ReadWritableAddressSpace<'_> {}

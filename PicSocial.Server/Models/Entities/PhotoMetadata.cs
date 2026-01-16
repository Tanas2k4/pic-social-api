namespace PicSocial.Server.Models.Entities
{
    public class PhotoMetadata
    {
        //Thông số kỹ thuật của ảnh
        public Guid PhotoMetadataId { get; set; } = Guid.NewGuid();
        public Guid PhotoId { get; set; }
        public string? Lens { get; set; } // Ống kính - ví dụ: Canon EF 50mm f/1.8 STM
        public string? Aperture { get; set; } //Khẩu độ - ví dụ: f/1.8
        public string? ShutterSpeed { get; set; } //Tốc độ màn trập - ví dụ: 1/200s
        public int? ISO { get; set; } //Độ nhạy sáng ISO - ví dụ: 100, 200, 400
        public string? CameraModel { get; set; } // Mẫu máy ảnh - ví dụ: Canon EOS 5D Mark IV
        public string? Location { get; set; } // Vị trí chụp ảnh - ví dụ: "Hà Nội, Việt Nam"
        public string? IPTCKeywords { get; set; } // ListKeywords dạng JSON (từ Metadata EXIF/IPTC)
        public string? IPTCCaption { get; set; } // Chú thích ảnh

        // Navigation property
        public Photo Photo { get; set; } = null!;
    }
}

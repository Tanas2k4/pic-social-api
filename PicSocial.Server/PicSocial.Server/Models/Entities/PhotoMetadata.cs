namespace PicSocial.Server.Models.Entities
{
    public class PhotoMetadata
    {
        //Thông số kỹ thuật của ảnh
        public Guid PhotoMetadataId { get; set; } = Guid.NewGuid();
        public Guid PhotoId { get; set; }
        public string? Lens { get; set; }
        public decimal? Aperture { get; set; } //Khẩu độ
        public string? ShutterSpeed { get; set; } //Tốc độ màn trập
        public int? ISO { get; set; }
        public string? CameraModel { get; set; }
        public string? Location { get; set; }
        public string? IPTCKeywords { get; set; } // JSON array
        public string? IPTCCaption { get; set; }

        // Navigation property
        public Photo Photo { get; set; } = null!;
    }
}
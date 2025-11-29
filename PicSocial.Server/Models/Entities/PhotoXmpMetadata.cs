namespace PicSocial.Server.Models.Entities
{
    public class PhotoXmpMetadata
    {
        public Guid PhotoXmpMetadataId { get; set; } = Guid.NewGuid();
        public Guid PhotoId { get; set; }
        public string? RawXmp { get; set; } // Lưu toàn bộ XML/XMP để reference
        public int? Rating { get; set; } // Đánh giá từ 1 đến 5 sao
        public string? Title { get; set; } //
        public string? Caption { get; set; } //
        public string? KeywordsJson { get; set; } // ListKeywords dạng JSON
        public string? ColorLabel { get; set; } // Red, Yellow, Green, Blue, Purple, None

        // Navigation property
        public Photo Photo { get; set; } = null!;

    }
}

namespace PicSocial.Server.DTOs.PhotosDto
{
    public class PhotoDetailDto
    {
        public Guid PhotoId { get; set; }
        public Guid PostId { get; set; }
        public string UserId { get; set; } = null!;
        public bool AllowDownload { get; set; } = false;
        public int? MaxPublicResolution { get; set; }
        public PhotoXmpMetadataDto? photoXmpMetadataDto { get; set; }
        public PhotoMetadataDto? photoMetadataDto { get; set; }
        public DateTimeOffset CreatedDate { get; set; }
        public DateTimeOffset? UpdatedDate { get; set; }
    }
}

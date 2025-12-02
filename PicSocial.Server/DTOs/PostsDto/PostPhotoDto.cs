namespace PicSocial.Server.DTOs.PostsDto
{
    public class PostPhotoDto
    {
        public Guid PhotoId { get; set; }
        public string? OriginalFileUrl { get; set; } 
        public bool IsPublic { get; set; }
        public bool AllowDownload { get; set; } = false;
        public int? MaxPublicResolution { get; set; }
    }
}

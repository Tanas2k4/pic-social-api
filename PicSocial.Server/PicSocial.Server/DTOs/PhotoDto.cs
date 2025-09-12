namespace PicSocial.Server.DTOs
{
    public class PhotoDto
    {
        public Guid PhotoId { get; set; }
        public string OriginalFileUrl { get; set; } = null!;
    }
}
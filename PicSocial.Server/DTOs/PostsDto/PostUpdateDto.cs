namespace PicSocial.Server.DTOs.PostsDto
{
    public class PostUpdateDto
    {
        public string Title { get; set; } = "";
        public Guid? LicenseId { get; set; }
    }
}
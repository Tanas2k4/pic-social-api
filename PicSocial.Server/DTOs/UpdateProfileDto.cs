namespace PicSocial.Server.DTOs
{
    public class UpdateProfileDto
    {
        public string? UserName { get; set; }
        public string? FirstName { get; set; }
        public string? Bio { get; set; }
        // public string? AvatarUrl { get; set; }
        // public string? CoverPhotoUrl { get; set; }
        public string? Location { get; set; }       
       
    }
}
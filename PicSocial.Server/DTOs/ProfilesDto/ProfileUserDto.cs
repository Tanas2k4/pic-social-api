namespace PicSocial.Server.DTOs.ProfilesDto
{
    public class ProfileUserDto
    {
        public string UserName { get; set; } = null!;
        public string? FirstName { get; set; }
        public string? Bio { get; set; }
        public string? AvatarUrl { get; set; }
        public string? CoverPhotoUrl { get; set; }
        public string? Location { get; set; } //use later  
        public int FollowersCount { get; set; } 
        public int FollowingCount { get; set; }
    }
}
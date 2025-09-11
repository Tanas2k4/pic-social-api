namespace PicSocial.Server.DTOs
{
    public class FollowDto
    {
        public string Id { get; set; } = null!; 
        public string? FollowerId { get; set; }
        public string? FollowedId { get; set; }
        public int? FollowerCount { get; set; } = 0;
        public int? FollowingCount { get; set; } = 0;
    }
}
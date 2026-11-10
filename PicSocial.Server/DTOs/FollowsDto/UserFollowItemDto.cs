namespace PicSocial.Server.DTOs.FollowsDto
{
    public class FollowerItemDto
    {
        public string? FollowerUserName { get; set; }
        public string? FollowerFirstName { get; set; }
        public string? FollowerAvatar { get; set; }
    }

    public class FollowingItemDto
    {
        public string? FollowingUserName { get; set; }
        public string? FollowingFirstName { get; set; }
        public string? FollowingAvatar { get; set; }
    }
}

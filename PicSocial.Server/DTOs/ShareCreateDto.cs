namespace PicSocial.Server.DTOs
{
    public class ShareCreateDto
    {
        public string? Message { get; set; }
        public ShareDetailDto? Share { get; set; }
    }

    public class ShareDetailDto
    {
        public Guid PostId { get; set; }
        public string? ShareUserName { get; set; }
        public string? Caption { get; set; }
        public string? SharePlatform { get; set; }
        public DateTimeOffset CreatedDate { get; set; }
        public object Post { get; set; } = null!;
    }
}
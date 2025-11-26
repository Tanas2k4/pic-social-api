namespace PicSocial.Server.DTOs.SharesDto
{
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

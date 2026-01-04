namespace PicSocial.Server.DTOs.SharesDto
{
    public class ShareCreateDto
    {
        public string? Message { get; set; }
        public ShareDetailDto? Share { get; set; }
    }
}
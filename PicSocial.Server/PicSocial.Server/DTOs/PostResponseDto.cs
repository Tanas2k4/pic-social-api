using PicSocial.Server.Controllers;

namespace PicSocial.Server.DTOs
{
    public class PostResponseDto
    {
        public string UserName { get; set; } = null!;
        public string? Title { get; set; }
        public DateTimeOffset CreateDate { get; set; }
        public List<PhotoDto> Photos { get; set; } = new List<PhotoDto>();    
    }
}
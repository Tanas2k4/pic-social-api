namespace PicSocial.Server.DTOs.PostsDto
{
    public class PostResponseDto
    {
        public Guid PostId { get; set; }
        public string UserId { get; set; } = null!;
        public string? Title { get; set; } 
        public DateTimeOffset CreatedDate { get; set; }
        public DateTimeOffset? UpdatedDate { get; set; }
        public List<PostPhotoDto> Photos { get; set; } = new();
    }
}

namespace PicSocial.Server.DTOs
{
    public class CommentCreateDto
    {
        public Guid CommentId { get; set; }
        public string Content { get; set; } = null!;
        public DateTimeOffset? CreateDate { get; set; }
        public string? UserName { get; set; }
        public string? Avatar { get; set; }
    }
}

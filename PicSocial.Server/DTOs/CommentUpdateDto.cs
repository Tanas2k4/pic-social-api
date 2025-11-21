namespace PicSocial.Server.DTOs
{
    public class CommentUpdateDto
    {
        public Guid CommentId { get; set; }
        public string Content { get; set; } = null!;
        public DateTimeOffset? UpdateDate { get; set; }
        public string? UserName { get; set; }
        public string? Avatar { get; set; }
    }
}

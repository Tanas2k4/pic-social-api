namespace PicSocial.Server.DTOs
{
    public class CommentPostDto
    {
        public Guid CommentId { get; set; }
        public Guid? ParentCommentId { get; set; }     
        public string? UserName { get; set; }
        public string? Avatar { get; set; }
        public string? Content { get; set; }
        public DateTimeOffset? CreateDate { get; set; }
        public DateTimeOffset? UpdateDate { get; set; }
        public List<CommentPostDto>? Replies { get; set; }

    }
}

namespace PicSocial.Server.DTOs
{
    public class CommentDto
    {
        public Guid? ParentCommentId { get; set;}
        public string Content { get; set; } = null!;
    }
}
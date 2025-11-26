namespace PicSocial.Server.DTOs.CommentsDto
{
    public class CommentDto
    {
        public Guid? ParentCommentId { get; set;}
        public string Content { get; set; } = null!;
    }
}
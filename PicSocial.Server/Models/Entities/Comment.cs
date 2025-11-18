using PicSocial.Server.Models.Interfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace PicSocial.Server.Models.Entities
{
    public class Comment : IDateTracking
    {
        public Guid CommentId { get; set; } = Guid.NewGuid();
        public Guid PostId { get; set; }
        public string UserId { get; set; } = null!;        
        public string? Content { get; set; }
        public DateTimeOffset CreatedDate { get; set; }
        public DateTimeOffset? UpdatedDate { get; set; }
        public Guid? ParentCommentId { get; set; }

        // Navigation properties
        public Post Post { get; set; } = null!;
        public ApplicationUser User { get; set; } = null!;
        public Comment? ParentComment { get; set; }
        public ICollection<Comment> ChildComments { get; set; } = new List<Comment>();
    }
}
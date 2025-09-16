using PicSocial.Server.Models.Interfaces;

namespace PicSocial.Server.Models.Entities
{
    public class Post : IDateTracking
    {
        public Guid PostId { get; set; } = Guid.NewGuid();
        public string UserId { get; set; } = null!;
        public string? Title { get; set; }
        public DateTimeOffset CreatedDate { get; set; }
        public DateTimeOffset? UpdatedDate { get; set; }
        public int LikeCount { get; set; } = 0;

        // Navigation properties
        public ApplicationUser User { get; set; } = null!;
        public ICollection<Photo> Photos { get; set; } = new List<Photo>();
        public ICollection<Reaction> Likes { get; set; } = new List<Reaction>();
        public ICollection<Comment> Comments { get; set; } = new List<Comment>();
    }
}

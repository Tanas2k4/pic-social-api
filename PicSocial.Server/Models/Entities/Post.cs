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
        public int ReactionCount { get; set; } = 0;
        public int CommentCount { get; set; } = 0;
        public int ShareCount { get; set; } = 0;

        public Guid? LicenseId { get; set; } 
        public License? License { get; set; }
        // Navigation properties
        public ApplicationUser User { get; set; } = null!;
        public ICollection<Photo> Photos { get; set; } = new List<Photo>();
        public ICollection<Reaction> Likes { get; set; } = new List<Reaction>();
        public ICollection<Comment> Comments { get; set; } = new List<Comment>();
        public ICollection<Share> Shares { get; set; } = new List<Share>();
        public ICollection<Report> Reports { get; set; } = new List<Report>();
    }
}

using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.Models.Entities;

namespace PicSocial.Server.Models
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Follow> Follows { get; set; }
        public DbSet<Photo> Photos { get; set; }
        public DbSet<PhotoVersion> PhotoVersions { get; set; }
        public DbSet<PhotoMetadata> PhotoMetadata { get; set; }
        public DbSet<License> Licenses { get; set; } = null!;
        public DbSet<PhotoLicense> PhotoLicenses { get; set; }
        public DbSet<Album> Albums { get; set; }
        public DbSet<AlbumPhoto> AlbumPhotos { get; set; }
        public DbSet<Tag> Tags { get; set; } = null!;
        public DbSet<PhotoTag> PhotoTags { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<Reaction> Reactions { get; set; }
        public DbSet<Share> Shares { get; set; }
        public DbSet<Report> Reports { get; set; }
        public DbSet<Post> Posts { get; set; }
        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Configure Follows
            builder.Entity<Follow>()
                .HasKey(f => f.FollowId);

            builder.Entity<Follow>()
                .HasIndex(f => new { f.FollowerId, f.FollowedId })
                .IsUnique();

            builder.Entity<Follow>()
                .HasOne(f => f.Follower)
                .WithMany(u => u.FollowerFollows)
                .HasForeignKey(f => f.FollowerId)
                .OnDelete(DeleteBehavior.ClientSetNull);

            builder.Entity<Follow>()
                .HasOne(f => f.Followed)
                .WithMany(u => u.FollowedFollows)
                .HasForeignKey(f => f.FollowedId)
                .OnDelete(DeleteBehavior.ClientSetNull);

            // Configure Photos
            builder.Entity<Photo>()
                .HasOne(p => p.Post)
                .WithMany(p => p.Photos)
                .HasForeignKey(p => p.PostId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Photo>()
                .HasOne(p => p.User)
                .WithMany(u => u.Photos)
                .HasForeignKey(p => p.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure PhotoVersions
            builder.Entity<PhotoVersion>()
                .HasKey(pv => pv.PhotoVersionId);

            builder.Entity<PhotoVersion>()
                .HasOne(pv => pv.Photo)
                .WithMany(p => p.Versions)
                .HasForeignKey(pv => pv.PhotoId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure PhotoMetadata
            builder.Entity<PhotoMetadata>()
                .HasKey(pm => pm.PhotoMetadataId);

            builder.Entity<PhotoMetadata>()
                .HasOne(pm => pm.Photo)
                .WithOne(p => p.Metadata)
                .HasForeignKey<PhotoMetadata>(pm => pm.PhotoId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<PhotoMetadata>()
                .Property(pm => pm.Aperture)
                .HasPrecision(4, 2);

            builder.Entity<PhotoMetadata>()
                .HasIndex(pm => pm.Lens);

            builder.Entity<PhotoMetadata>()
                .HasIndex(pm => pm.Aperture);

            builder.Entity<PhotoMetadata>()
                .HasIndex(pm => pm.ISO);

            // Configure Licenses
            builder.Entity<License>()
                .HasKey(l => l.LicenseId);

            builder.Entity<License>()
                .HasIndex(l => l.Name)
                .IsUnique();

            // Configure PhotoLicenses
            builder.Entity<PhotoLicense>()
                .HasKey(pl => pl.PhotoLicenseId);

            builder.Entity<PhotoLicense>()
                .HasOne(pl => pl.Photo)
                .WithOne(p => p.License)
                .HasForeignKey<PhotoLicense>(pl => pl.PhotoId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<PhotoLicense>()
                .HasOne(pl => pl.License)
                .WithMany(l => l.PhotoLicenses)
                .HasForeignKey(pl => pl.LicenseId)
                .OnDelete(DeleteBehavior.Restrict);

            // Configure Albums (tránh lỗi multiple cascade path)
            builder.Entity<Album>()
                .HasKey(a => a.AlbumId);

            builder.Entity<Album>()
                .HasIndex(a => a.UserId);

            builder.Entity<Album>()
                .HasOne<ApplicationUser>()
                .WithMany(u => u.Albums)
                .HasForeignKey(a => a.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull);    // QUAN TRỌNG: không dùng Cascade ở đây

            // Configure AlbumPhotos
            builder.Entity<AlbumPhoto>()
                .HasKey(ap => new { ap.AlbumId, ap.PhotoId });

            builder.Entity<AlbumPhoto>()
                .HasOne(ap => ap.Album)
                .WithMany(a => a.AlbumPhotos)
                .HasForeignKey(ap => ap.AlbumId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<AlbumPhoto>()
                .HasOne(ap => ap.Photo)
                .WithMany(p => p.AlbumPhotos)
                .HasForeignKey(ap => ap.PhotoId)
                .OnDelete(DeleteBehavior.Restrict);

            // Configure Tags
            builder.Entity<Tag>()
                .HasKey(t => t.TagId);

            builder.Entity<Tag>()
                .HasIndex(t => t.Name)
                .IsUnique();

            // Configure PhotoTags
            builder.Entity<PhotoTag>()
                .HasKey(pt => new { pt.PhotoId, pt.TagId });

            builder.Entity<PhotoTag>()
                .HasOne(pt => pt.Photo)
                .WithMany(p => p.PhotoTags)
                .HasForeignKey(pt => pt.PhotoId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<PhotoTag>()
                .HasOne(pt => pt.Tag)
                .WithMany(t => t.PhotoTags)
                .HasForeignKey(pt => pt.TagId)
                .OnDelete(DeleteBehavior.Restrict);

            // Configure Comments
            builder.Entity<Comment>()
                .HasKey(c => c.CommentId);

            builder.Entity<Comment>()
                .HasIndex(c => c.PostId);

            builder.Entity<Comment>()
                .HasOne(c => c.Post)
                .WithMany(p => p.Comments)
                .HasForeignKey(c => c.PostId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Comment>()
                .HasOne(c => c.User)
                .WithMany()
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Comment>()
                .HasOne(c => c.ParentComment)
                .WithMany(c => c.ChildComments)
                .HasForeignKey(c => c.ParentCommentId)
                .OnDelete(DeleteBehavior.Restrict);

            // Configure Reactions (Like)
            builder.Entity<Reaction>()
                .HasKey(r => r.ReactionId);

            builder.Entity<Reaction>()
                .HasIndex(r => new { r.PostId, r.UserId })
                .IsUnique();

            builder.Entity<Reaction>()
                .HasOne(r => r.Post)
                .WithMany(p => p.Likes)
                .HasForeignKey(r => r.PostId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Reaction>()
                .HasOne(r => r.User)
                .WithMany()
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure Shares
            builder.Entity<Share>()
                .HasKey(s => s.ShareId);

            builder.Entity<Share>()
                .HasIndex(s => s.PostId);

            builder.Entity<Share>()
                .HasOne(s => s.Post)
                .WithMany(p => p.Shares)
                .HasForeignKey(s => s.PostId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Share>()
                .HasOne(s => s.User)
                .WithMany()
                .HasForeignKey(s => s.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure Reports
            builder.Entity<Report>()
                .HasKey(r => r.ReportId);

            builder.Entity<Report>()
                .HasIndex(r => r.Status);

            builder.Entity<Report>()
                .HasIndex(r => r.PostId);

            builder.Entity<Report>()
                .HasOne(r => r.Post)
                .WithMany(p => p.Reports)
                .HasForeignKey(r => r.PostId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Report>()
                .HasOne(r => r.User)
                .WithMany()
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure Posts
            builder.Entity<Post>()
                .HasKey(p => p.PostId);

            builder.Entity<Post>()
                .HasOne(p => p.User)
                .WithMany(u => u.Posts)
                .HasForeignKey(p => p.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
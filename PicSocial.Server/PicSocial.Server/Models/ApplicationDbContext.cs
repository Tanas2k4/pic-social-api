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
        public DbSet<License> Licenses { get; set; }
        public DbSet<PhotoLicense> PhotoLicenses { get; set; }
        public DbSet<Album> Albums { get; set; }
        public DbSet<AlbumPhoto> AlbumPhotos { get; set; }
        public DbSet<Tag> Tags { get; set; }
        public DbSet<PhotoTag> PhotoTags { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<Like> Likes { get; set; }
        public DbSet<Share> Shares { get; set; }
        public DbSet<Report> Reports { get; set; }

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
                .OnDelete(DeleteBehavior.Restrict);
            builder.Entity<Follow>()
                .HasOne(f => f.Followed)
                .WithMany(u => u.FollowedFollows)
                .HasForeignKey(f => f.FollowedId)
                .OnDelete(DeleteBehavior.Restrict);

            // Configure Photos
            builder.Entity<Photo>()
                .HasKey(p => p.PhotoId);
            builder.Entity<Photo>()
                .HasIndex(p => p.UserId);
            builder.Entity<Photo>()
                .HasIndex(p => p.CreatedDate);
            builder.Entity<Photo>()
                .HasIndex(p => p.Visibility);
            builder.Entity<Photo>()
                .Property(p => p.Visibility)
                .HasDefaultValue("Public");

            // Configure PhotoVersions
            builder.Entity<PhotoVersion>()
                .HasKey(pv => pv.PhotoVersionId);
            builder.Entity<PhotoVersion>()
                .HasOne(pv => pv.Photo)
                .WithMany(p => p.Versions)
                .HasForeignKey(pv => pv.PhotoId);

            // Configure PhotoMetadata
            builder.Entity<PhotoMetadata>()
                .HasKey(pm => pm.PhotoMetadataId);
            builder.Entity<PhotoMetadata>()
                .HasOne(pm => pm.Photo)
                .WithOne(p => p.Metadata)
                .HasForeignKey<PhotoMetadata>(pm => pm.PhotoId);
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
                .HasForeignKey<PhotoLicense>(pl => pl.PhotoId);
            builder.Entity<PhotoLicense>()
                .HasOne(pl => pl.License)
                .WithMany(l => l.PhotoLicenses)
                .HasForeignKey(pl => pl.LicenseId);

            // Configure Albums
            builder.Entity<Album>()
                .HasKey(a => a.AlbumId);
            builder.Entity<Album>()
                .HasIndex(a => a.UserId);

            // Configure AlbumPhotos
            builder.Entity<AlbumPhoto>()
                .HasKey(ap => new { ap.AlbumId, ap.PhotoId });
            builder.Entity<AlbumPhoto>()
                .HasOne(ap => ap.Album)
                .WithMany(a => a.AlbumPhotos)
                .HasForeignKey(ap => ap.AlbumId);
            builder.Entity<AlbumPhoto>()
                .HasOne(ap => ap.Photo)
                .WithMany(p => p.AlbumPhotos)
                .HasForeignKey(ap => ap.PhotoId);

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
                .HasForeignKey(pt => pt.PhotoId);
            builder.Entity<PhotoTag>()
                .HasOne(pt => pt.Tag)
                .WithMany(t => t.PhotoTags)
                .HasForeignKey(pt => pt.TagId);

            // Configure Comments
            builder.Entity<Comment>()
                .HasKey(c => c.CommentId);
            builder.Entity<Comment>()
                .HasIndex(c => c.PhotoId);
            builder.Entity<Comment>()
                .HasOne(c => c.ParentComment)
                .WithMany(c => c.ChildComments)
                .HasForeignKey(c => c.ParentCommentId);

            // Configure Likes
            builder.Entity<Like>()
                .HasKey(l => l.LikeId);
            builder.Entity<Like>()
                .HasIndex(l => new { l.PhotoId, l.UserId })
                .IsUnique();
            builder.Entity<Like>()
                .HasIndex(l => l.PhotoId);

            // Configure Shares
            builder.Entity<Share>()
                .HasKey(s => s.ShareId);
            builder.Entity<Share>()
                .HasIndex(s => s.PhotoId);

            // Configure Reports
            builder.Entity<Report>()
                .HasKey(r => r.ReportId);
            builder.Entity<Report>()
                .HasIndex(r => r.Status);
            builder.Entity<Report>()
                .HasIndex(r => r.PhotoId);

            //// Seed Roles
            //builder.Entity<IdentityRole>().HasData(
            //    new IdentityRole { Id = Guid.NewGuid().ToString(), Name = "Admin", NormalizedName = "ADMIN" },
            //    new IdentityRole { Id = Guid.NewGuid().ToString(), Name = "User", NormalizedName = "USER" }
            //);

            //// Seed Licenses
            //builder.Entity<License>().HasData(
            //    new License { LicenseId = Guid.NewGuid(), Name = "All Rights Reserved", Description = "All rights reserved by the photographer." },
            //    new License { LicenseId = Guid.NewGuid(), Name = "CC-BY", Description = "Creative Commons Attribution." },
            //    new License { LicenseId = Guid.NewGuid(), Name = "Royalty-Free", Description = "Royalty-free license for commercial use." }
            //);
        }
    }
}
using Microsoft.AspNetCore.Identity;
using PicSocial.Server.Models.Entities;
using System;
using System.Collections.Generic;

namespace PicSocial.Server.Models
{
    public class ApplicationUser : IdentityUser
    {
        public string? FirstName { get; set; }
        public string? Bio { get; set; }
        public string? AvatarUrl { get; set; } 
        public string? CoverPhotoUrl { get; set; }
        public string? Location { get; set; }
        public string? Website { get; set; }
        public int FollowersCount { get; set; } = 0;
        public int FollowingCount { get; set; } = 0;

        // Navigation properties
        public ICollection<Photo> Photos { get; set; } = new List<Photo>();
        public ICollection<Follow> FollowerFollows { get; set; } = new List<Follow>();
        public ICollection<Follow> FollowedFollows { get; set; } = new List<Follow>();
        public ICollection<Album> Albums { get; set; } = new List<Album>();
        public ICollection<Comment> Comments { get; set; } = new List<Comment>();
        public ICollection<Like> Likes { get; set; } = new List<Like>();
        public ICollection<Share> Shares { get; set; } = new List<Share>();
        public ICollection<Report> Reports { get; set; } = new List<Report>();
    }
}
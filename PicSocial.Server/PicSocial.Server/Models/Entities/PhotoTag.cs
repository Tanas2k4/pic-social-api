using System;

namespace PicSocial.Server.Models.Entities
{
    public class PhotoTag
    {
        public Guid PhotoId { get; set; }
        public Guid TagId { get; set; }

        // Navigation properties
        public Photo Photo { get; set; } = null!;
        public Tag Tag { get; set; } = null!;
    }
}
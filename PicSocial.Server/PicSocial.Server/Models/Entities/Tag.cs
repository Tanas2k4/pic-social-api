using System;
using System.Collections.Generic;

namespace PicSocial.Server.Models.Entities
{
    public class Tag
    {
        public Guid TagId { get; set; } = Guid.NewGuid();
        public string Name { get; set; } = null!;
        public string? Type { get; set; }

        // Navigation property
        public ICollection<PhotoTag> PhotoTags { get; set; } = new List<PhotoTag>();
    }
}
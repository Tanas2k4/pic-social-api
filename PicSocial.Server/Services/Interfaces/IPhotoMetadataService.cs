using PicSocial.Server.Models.Entities;
namespace PicSocial.Server.Services.Interfaces
{
    public interface IPhotoMetadataService
    {
        //implement method to extract metadata from image file
        PhotoMetadata ExtractExifIptc(Stream stream, Guid photoId);
    }
}
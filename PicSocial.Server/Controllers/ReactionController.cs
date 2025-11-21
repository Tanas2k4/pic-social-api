using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ReactionController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ApplicationDbContext _context;
        private readonly IReactionService _reactionService;
        public ReactionController(UserManager<ApplicationUser> userManager, ApplicationDbContext context, IReactionService reactionService)
        {
            _userManager = userManager;
            _context = context;
            _reactionService = reactionService;
        }

        //POST api/reaction/
        [HttpPost("{postId}")]
        public async Task<IActionResult> ReactionPost(Guid postId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _reactionService.ReactionPostAsync(currentUser.Id, postId);
            return StatusCode(result.StatusCode, new {message = result.Message});
        }  
    }
}
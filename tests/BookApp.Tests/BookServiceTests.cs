using BookApp.Services;
using Xunit;

namespace BookApp.Tests;

public class BookServiceTests
{
    [Fact]
    public void GetAllBooks_ReturnsThreeBooks()
    {
        var service = new BookService();
        var books = service.GetAllBooks();
        Assert.Equal(3, books.Count);
    }

    [Fact]
    public void GetAllBooks_IncludesCleanCode()
    {
        var service = new BookService();
        var books = service.GetAllBooks();
        Assert.Contains(books, b => b.Title == "Clean Code");
    }
}

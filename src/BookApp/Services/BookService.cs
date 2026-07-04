using BookApp.Models;

namespace BookApp.Services;

public interface IBookService
{
    IReadOnlyList<Book> GetAllBooks();
}

public class BookService : IBookService
{
    private readonly List<Book> _books = new()
    {
        new Book { Id = 1, Title = "The Pragmatic Programmer", Author = "Hunt & Thomas", Year = 1999 },
        new Book { Id = 2, Title = "Clean Code",              Author = "Robert C. Martin", Year = 2008 },
        new Book { Id = 3, Title = "The Mythical Man-Month",  Author = "Fred Brooks",      Year = 1975 },
    };

    public IReadOnlyList<Book> GetAllBooks() => _books;
}

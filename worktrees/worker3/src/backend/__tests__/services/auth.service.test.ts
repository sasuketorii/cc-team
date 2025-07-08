import { authService } from '../../services/auth.service';
import { userRepository } from '../../repositories/user.repository';
import { tokenService } from '../../services/token.service';
import { hashService } from '../../services/hash.service';
import { ValidationError } from '../../errors/ValidationError';

// モック
jest.mock('../../repositories/user.repository');
jest.mock('../../services/token.service');
jest.mock('../../services/hash.service');

describe('Auth Service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('register', () => {
    it('should register a new user successfully', async () => {
      const mockUser = {
        id: '123',
        email: 'test@example.com',
        username: 'testuser',
        password: 'hashedpassword',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      (userRepository.findByEmail as jest.Mock).mockResolvedValue(null);
      (hashService.hash as jest.Mock).mockResolvedValue('hashedpassword');
      (userRepository.create as jest.Mock).mockResolvedValue(mockUser);
      (tokenService.generateToken as jest.Mock).mockReturnValue('mock-jwt-token');

      const result = await authService.register({
        email: 'test@example.com',
        username: 'testuser',
        password: 'password123',
      });

      expect(result).toEqual({
        user: expect.objectContaining({
          id: '123',
          email: 'test@example.com',
          username: 'testuser',
        }),
        token: 'mock-jwt-token',
      });

      expect(userRepository.findByEmail).toHaveBeenCalledWith('test@example.com');
      expect(hashService.hash).toHaveBeenCalledWith('password123');
      expect(userRepository.create).toHaveBeenCalledWith({
        email: 'test@example.com',
        username: 'testuser',
        password: 'hashedpassword',
      });
    });

    it('should throw error if email already exists', async () => {
      (userRepository.findByEmail as jest.Mock).mockResolvedValue({
        id: 'existing',
        email: 'test@example.com',
      });

      await expect(authService.register({
        email: 'test@example.com',
        username: 'testuser',
        password: 'password123',
      })).rejects.toThrow(ValidationError);

      expect(userRepository.create).not.toHaveBeenCalled();
    });

    it('should validate password strength', async () => {
      await expect(authService.register({
        email: 'test@example.com',
        username: 'testuser',
        password: '123', // Too weak
      })).rejects.toThrow(ValidationError);
    });
  });

  describe('login', () => {
    it('should login successfully with valid credentials', async () => {
      const mockUser = {
        id: '123',
        email: 'test@example.com',
        username: 'testuser',
        password: 'hashedpassword',
      };

      (userRepository.findByEmail as jest.Mock).mockResolvedValue(mockUser);
      (hashService.compare as jest.Mock).mockResolvedValue(true);
      (tokenService.generateToken as jest.Mock).mockReturnValue('mock-jwt-token');

      const result = await authService.login({
        email: 'test@example.com',
        password: 'password123',
      });

      expect(result).toEqual({
        user: expect.objectContaining({
          id: '123',
          email: 'test@example.com',
          username: 'testuser',
        }),
        token: 'mock-jwt-token',
      });

      expect(hashService.compare).toHaveBeenCalledWith('password123', 'hashedpassword');
    });

    it('should throw error for invalid email', async () => {
      (userRepository.findByEmail as jest.Mock).mockResolvedValue(null);

      await expect(authService.login({
        email: 'nonexistent@example.com',
        password: 'password123',
      })).rejects.toThrow('Invalid credentials');
    });

    it('should throw error for invalid password', async () => {
      const mockUser = {
        id: '123',
        email: 'test@example.com',
        password: 'hashedpassword',
      };

      (userRepository.findByEmail as jest.Mock).mockResolvedValue(mockUser);
      (hashService.compare as jest.Mock).mockResolvedValue(false);

      await expect(authService.login({
        email: 'test@example.com',
        password: 'wrongpassword',
      })).rejects.toThrow('Invalid credentials');
    });
  });

  describe('logout', () => {
    it('should blacklist token on logout', async () => {
      const mockBlacklist = jest.fn();
      (tokenService.blacklistToken as jest.Mock).mockImplementation(mockBlacklist);

      await authService.logout('mock-jwt-token');

      expect(mockBlacklist).toHaveBeenCalledWith('mock-jwt-token');
    });
  });

  describe('getCurrentUser', () => {
    it('should return current user from token', async () => {
      const mockUser = {
        id: '123',
        email: 'test@example.com',
        username: 'testuser',
      };

      (tokenService.verifyToken as jest.Mock).mockReturnValue({ userId: '123' });
      (userRepository.findById as jest.Mock).mockResolvedValue(mockUser);

      const result = await authService.getCurrentUser('mock-jwt-token');

      expect(result).toEqual(mockUser);
      expect(tokenService.verifyToken).toHaveBeenCalledWith('mock-jwt-token');
      expect(userRepository.findById).toHaveBeenCalledWith('123');
    });

    it('should throw error for invalid token', async () => {
      (tokenService.verifyToken as jest.Mock).mockImplementation(() => {
        throw new Error('Invalid token');
      });

      await expect(authService.getCurrentUser('invalid-token'))
        .rejects.toThrow('Invalid token');
    });
  });
});
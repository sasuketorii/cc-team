import api from './api';
import { Task, TaskFormData } from '../types/Task';

export interface TasksResponse {
  tasks: Task[];
  total: number;
  page: number;
  limit: number;
}

export interface TaskFilters {
  status?: Task['status'];
  priority?: Task['priority'];
  assignee?: string;
  search?: string;
  page?: number;
  limit?: number;
}

class TaskService {
  async getTasks(filters?: TaskFilters): Promise<TasksResponse> {
    return await api.get<TasksResponse>('/tasks', filters);
  }

  async getTask(id: string): Promise<Task> {
    return await api.get<Task>(`/tasks/${id}`);
  }

  async createTask(data: TaskFormData): Promise<Task> {
    const taskData = {
      ...data,
      status: 'todo' as Task['status'],
      tags: data.tags?.filter(tag => tag.trim() !== '') || []
    };
    return await api.post<Task>('/tasks', taskData);
  }

  async updateTask(id: string, data: Partial<Task>): Promise<Task> {
    return await api.put<Task>(`/tasks/${id}`, data);
  }

  async deleteTask(id: string): Promise<void> {
    await api.delete(`/tasks/${id}`);
  }

  async updateTaskStatus(id: string, status: Task['status']): Promise<Task> {
    return await api.patch<Task>(`/tasks/${id}/status`, { status });
  }

  async assignTask(id: string, assignee: string): Promise<Task> {
    return await api.patch<Task>(`/tasks/${id}/assign`, { assignee });
  }

  async addTaskTag(id: string, tag: string): Promise<Task> {
    return await api.post<Task>(`/tasks/${id}/tags`, { tag });
  }

  async removeTaskTag(id: string, tag: string): Promise<Task> {
    return await api.delete<Task>(`/tasks/${id}/tags/${tag}`);
  }

  async getTasksByUser(userId: string, filters?: TaskFilters): Promise<TasksResponse> {
    return await api.get<TasksResponse>(`/users/${userId}/tasks`, filters);
  }

  async getMyTasks(filters?: TaskFilters): Promise<TasksResponse> {
    return await api.get<TasksResponse>('/tasks/my', filters);
  }
}

export default new TaskService();
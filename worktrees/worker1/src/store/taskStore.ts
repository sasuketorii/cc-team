import { create } from 'zustand';
import { Task, TaskFormData } from '../types/Task';

interface TaskState {
  tasks: Task[];
  filter: {
    status?: Task['status'];
    priority?: Task['priority'];
    searchTerm?: string;
  };
  addTask: (taskData: TaskFormData) => void;
  updateTask: (id: string, taskData: Partial<Task>) => void;
  deleteTask: (id: string) => void;
  setFilter: (filter: TaskState['filter']) => void;
  getFilteredTasks: () => Task[];
}

const useTaskStore = create<TaskState>((set, get) => ({
  tasks: [
    {
      id: '1',
      title: 'Setup project structure',
      description: 'Initialize the React TypeScript project with Tailwind CSS',
      status: 'done',
      priority: 'high',
      createdAt: new Date(),
      updatedAt: new Date(),
      assignee: 'Worker1',
      tags: ['setup', 'frontend']
    },
    {
      id: '2',
      title: 'Create Task components',
      description: 'Build TaskCard and TaskBoard components',
      status: 'done',
      priority: 'medium',
      createdAt: new Date(),
      updatedAt: new Date(),
      assignee: 'Worker1',
      tags: ['components', 'ui']
    },
    {
      id: '3',
      title: 'Implement state management',
      description: 'Add Zustand for state management',
      status: 'in_progress',
      priority: 'high',
      createdAt: new Date(),
      updatedAt: new Date(),
      assignee: 'Worker1',
      tags: ['features', 'state']
    }
  ],
  
  filter: {},
  
  addTask: (taskData) => set((state) => ({
    tasks: [...state.tasks, {
      ...taskData,
      id: Date.now().toString(),
      status: 'todo',
      createdAt: new Date(),
      updatedAt: new Date(),
      tags: taskData.tags?.filter(tag => tag.trim() !== '') || []
    }]
  })),
  
  updateTask: (id, taskData) => set((state) => ({
    tasks: state.tasks.map(task => 
      task.id === id 
        ? { ...task, ...taskData, updatedAt: new Date() }
        : task
    )
  })),
  
  deleteTask: (id) => set((state) => ({
    tasks: state.tasks.filter(task => task.id !== id)
  })),
  
  setFilter: (filter) => set({ filter }),
  
  getFilteredTasks: () => {
    const { tasks, filter } = get();
    let filteredTasks = [...tasks];
    
    if (filter.status) {
      filteredTasks = filteredTasks.filter(task => task.status === filter.status);
    }
    
    if (filter.priority) {
      filteredTasks = filteredTasks.filter(task => task.priority === filter.priority);
    }
    
    if (filter.searchTerm) {
      const searchLower = filter.searchTerm.toLowerCase();
      filteredTasks = filteredTasks.filter(task => 
        task.title.toLowerCase().includes(searchLower) ||
        task.description?.toLowerCase().includes(searchLower) ||
        task.tags?.some(tag => tag.toLowerCase().includes(searchLower))
      );
    }
    
    return filteredTasks.sort((a, b) => 
      new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime()
    );
  }
}));

export default useTaskStore;
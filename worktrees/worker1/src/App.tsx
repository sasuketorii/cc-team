import React, { useState } from 'react';
import { Task } from './types/Task';
import TaskBoard from './components/TaskBoard';

function App() {
  const [tasks, setTasks] = useState<Task[]>([
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
      status: 'in_progress',
      priority: 'medium',
      createdAt: new Date(),
      updatedAt: new Date(),
      assignee: 'Worker1',
      tags: ['components', 'ui']
    },
    {
      id: '3',
      title: 'Implement task management features',
      description: 'Add create, edit, delete functionality',
      status: 'todo',
      priority: 'high',
      createdAt: new Date(),
      updatedAt: new Date(),
      assignee: 'Worker1',
      tags: ['features']
    }
  ]);

  const handleStatusChange = (taskId: string, newStatus: Task['status']) => {
    setTasks(tasks.map(task => 
      task.id === taskId 
        ? { ...task, status: newStatus, updatedAt: new Date() }
        : task
    ));
  };

  const handleEdit = (task: Task) => {
    console.log('Edit task:', task);
    // TODO: Implement edit functionality
  };

  const handleDelete = (taskId: string) => {
    setTasks(tasks.filter(task => task.id !== taskId));
  };

  return (
    <div className="min-h-screen bg-gray-100">
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <h1 className="text-3xl font-bold text-gray-900">Task Management System</h1>
          <p className="text-gray-600 mt-1">Manage your tasks efficiently</p>
        </div>
      </header>
      
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-6 flex justify-between items-center">
          <h2 className="text-2xl font-semibold text-gray-800">All Tasks</h2>
          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
            Add New Task
          </button>
        </div>
        
        <TaskBoard 
          tasks={tasks}
          onStatusChange={handleStatusChange}
          onEdit={handleEdit}
          onDelete={handleDelete}
        />
      </main>
    </div>
  );
}

export default App;
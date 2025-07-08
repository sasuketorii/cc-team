import React, { useState } from 'react';
import useTaskStore from './store/taskStore';
import Header from './components/Header';
import FilterBar from './components/FilterBar';
import TaskList from './components/TaskList';
import TaskForm from './components/TaskForm';
import { Task } from './types/Task';

function App() {
  const { 
    addTask, 
    updateTask, 
    deleteTask, 
    setFilter, 
    getFilteredTasks, 
    filter 
  } = useTaskStore();
  
  const [viewMode, setViewMode] = useState<'board' | 'list'>('board');
  const [showTaskForm, setShowTaskForm] = useState(false);
  const [editingTask, setEditingTask] = useState<Task | undefined>(undefined);
  
  const filteredTasks = getFilteredTasks();

  const handleNewTask = () => {
    setEditingTask(undefined);
    setShowTaskForm(true);
  };

  const handleEditTask = (task: Task) => {
    setEditingTask(task);
    setShowTaskForm(true);
  };

  const handleTaskSubmit = (data: any) => {
    if (editingTask) {
      updateTask(editingTask.id, data);
    } else {
      addTask(data);
    }
    setShowTaskForm(false);
    setEditingTask(undefined);
  };

  const handleTaskCancel = () => {
    setShowTaskForm(false);
    setEditingTask(undefined);
  };

  const handleStatusChange = (taskId: string, newStatus: Task['status']) => {
    updateTask(taskId, { status: newStatus });
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <Header 
        currentView={viewMode}
        onViewChange={setViewMode}
        onNewTask={handleNewTask}
      />
      
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {showTaskForm ? (
          <div className="max-w-2xl mx-auto">
            <TaskForm
              task={editingTask}
              onSubmit={handleTaskSubmit}
              onCancel={handleTaskCancel}
            />
          </div>
        ) : (
          <>
            <FilterBar
              filter={filter}
              onFilterChange={setFilter}
              taskCount={filteredTasks.length}
            />
            
            <TaskList
              tasks={filteredTasks}
              viewMode={viewMode}
              onStatusChange={handleStatusChange}
              onEdit={handleEditTask}
              onDelete={deleteTask}
            />
          </>
        )}
      </main>
    </div>
  );
}

export default App;
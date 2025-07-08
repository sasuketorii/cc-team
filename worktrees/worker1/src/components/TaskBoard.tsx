import React from 'react';
import { Task } from '../types/Task';
import TaskCard from './TaskCard';

interface TaskBoardProps {
  tasks: Task[];
  onStatusChange: (taskId: string, newStatus: Task['status']) => void;
  onEdit: (task: Task) => void;
  onDelete: (taskId: string) => void;
}

const TaskBoard: React.FC<TaskBoardProps> = ({ tasks, onStatusChange, onEdit, onDelete }) => {
  const tasksByStatus = {
    todo: tasks.filter(task => task.status === 'todo'),
    in_progress: tasks.filter(task => task.status === 'in_progress'),
    done: tasks.filter(task => task.status === 'done'),
  };

  const columns: { status: Task['status']; title: string; bgColor: string }[] = [
    { status: 'todo', title: 'To Do', bgColor: 'bg-gray-50' },
    { status: 'in_progress', title: 'In Progress', bgColor: 'bg-blue-50' },
    { status: 'done', title: 'Done', bgColor: 'bg-green-50' },
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
      {columns.map(({ status, title, bgColor }) => (
        <div key={status} className={`p-4 rounded-lg ${bgColor}`}>
          <h2 className="text-xl font-bold mb-4 text-gray-800">{title}</h2>
          <div className="space-y-3">
            {tasksByStatus[status].map(task => (
              <TaskCard
                key={task.id}
                task={task}
                onStatusChange={onStatusChange}
                onEdit={onEdit}
                onDelete={onDelete}
              />
            ))}
            {tasksByStatus[status].length === 0 && (
              <p className="text-gray-500 text-center py-8">No tasks</p>
            )}
          </div>
        </div>
      ))}
    </div>
  );
};

export default TaskBoard;
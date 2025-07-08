import React from 'react';
import { Task } from '../types/Task';

interface FilterBarProps {
  filter: {
    status?: Task['status'];
    priority?: Task['priority'];
    searchTerm?: string;
  };
  onFilterChange: (filter: FilterBarProps['filter']) => void;
  taskCount: number;
}

const FilterBar: React.FC<FilterBarProps> = ({ filter, onFilterChange, taskCount }) => {
  const handleStatusChange = (status: string) => {
    onFilterChange({
      ...filter,
      status: status === 'all' ? undefined : status as Task['status']
    });
  };

  const handlePriorityChange = (priority: string) => {
    onFilterChange({
      ...filter,
      priority: priority === 'all' ? undefined : priority as Task['priority']
    });
  };

  const handleSearchChange = (searchTerm: string) => {
    onFilterChange({
      ...filter,
      searchTerm: searchTerm || undefined
    });
  };

  const clearFilters = () => {
    onFilterChange({});
  };

  const hasFilters = filter.status || filter.priority || filter.searchTerm;

  return (
    <div className="bg-white p-4 rounded-lg shadow-sm mb-6">
      <div className="flex flex-col md:flex-row gap-4 items-start md:items-center">
        <div className="flex-1">
          <input
            type="text"
            placeholder="Search tasks..."
            value={filter.searchTerm || ''}
            onChange={(e) => handleSearchChange(e.target.value)}
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
        
        <div className="flex flex-wrap gap-3 items-center">
          <div>
            <select
              value={filter.status || 'all'}
              onChange={(e) => handleStatusChange(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="all">All Status</option>
              <option value="todo">To Do</option>
              <option value="in_progress">In Progress</option>
              <option value="done">Done</option>
            </select>
          </div>
          
          <div>
            <select
              value={filter.priority || 'all'}
              onChange={(e) => handlePriorityChange(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="all">All Priority</option>
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
            </select>
          </div>
          
          {hasFilters && (
            <button
              onClick={clearFilters}
              className="px-4 py-2 text-sm text-gray-600 hover:text-gray-800 flex items-center gap-1"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
              Clear filters
            </button>
          )}
        </div>
      </div>
      
      <div className="mt-3 text-sm text-gray-600">
        Showing {taskCount} {taskCount === 1 ? 'task' : 'tasks'}
        {hasFilters && ' (filtered)'}
      </div>
    </div>
  );
};

export default FilterBar;
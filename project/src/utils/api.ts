// src/utils/api.ts
const API_URL = 'http://localhost:3001/api';

interface ApiResponse<T> {
  data: T | null;
  error: string | null;
}

class ApiClient {
  private async request<T>(
    endpoint: string,
    options?: RequestInit
  ): Promise<ApiResponse<T>> {
    try {
      const response = await fetch(`${API_URL}${endpoint}`, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...options?.headers,
        },
      });

      const json = await response.json();

      if (!response.ok) {
        return { data: null, error: json.error || 'Request failed' };
      }

      // ✅ Le backend retourne déjà { data: [...], error: null }
      // Donc on retourne directement json au lieu de { data: json, error: null }
      return json;
    } catch (error: any) {
      console.error('API Error:', error);
      return { data: null, error: error.message };
    }
  }

  from(table: string) {
    return {
      // ✅ SELECT - Support both filtered and unfiltered queries
      select: (columns = '*') => {
        // Create a promise that will be resolved when eq() is called or immediately
        let filterApplied = false;

        // Return an object that can be awaited OR chained with eq()
        const selectQuery = {
          eq: async (column: string, value: any) => {
            filterApplied = true;
            return this.request<any[]>(`/${table.toLowerCase()}?${column}=${encodeURIComponent(value)}`);
          },
          // Make the object thenable so it can be awaited directly
          then: (resolve: any, reject: any) => {
            // If eq() hasn't been called, fetch all records
            if (!filterApplied) {
              return this.request<any[]>(`/${table.toLowerCase()}`)
                .then(resolve)
                .catch(reject);
            }
          }
        };

        return selectQuery;
      },

      insert: async (data: Record<string, any> | Record<string, any>[]) => {
        const payload = Array.isArray(data) ? data[0] : data;
        return this.request<any>(`/${table.toLowerCase()}`, {
          method: 'POST',
          body: JSON.stringify(payload),
        });
      },

      update: (data: Record<string, any>) => ({
        eq: async (column: string, value: any) => {
          return this.request<any>(`/${table.toLowerCase()}/${value}`, {
            method: 'PUT',
            body: JSON.stringify(data),
          });
        },
      }),

      delete: () => ({
        eq: async (column: string, value: any) => {
          return this.request<any>(`/${table.toLowerCase()}/${value}`, {
            method: 'DELETE',
          });
        },
      }),
    };
  }

  async testConnection() {
    const result = await this.request<{ status: string }>('/health');
    return {
      success: result.data?.status === 'healthy',
      error: result.error,
    };
  }
}

export const api = new ApiClient();
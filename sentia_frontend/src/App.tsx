import React, { useState, useEffect, useCallback, useRef } from 'react';

type RowItem = {
  name: string;
  location: string;
  species: string;
  gender: string;
  affiliation: string | null;
  weapon: string | null;
  vehicle: string | null;
};

type CSVTableResponse = {
  total: number;
  data: RowItem[];
};

type SortOrder = 'desc' | 'asc';

const columns: (keyof RowItem)[] = [
  'name',
  'location',
  'species',
  'gender',
  'affiliation',
  'weapon',
  'vehicle',
];
const perPage = 10;
const API_BASE_URL = 'http://localhost:3000';
const CSV_LIST_PATH = '/people';
const CSV_UPLOAD_PATH = '/people/import';

const CsvImporter = () => {
  const [apiData, setData] = useState<CSVTableResponse>({ data: [], total: 0 });
  const [search, setSearch] = useState('');
  const [sortKey, setSortKey] = useState<keyof RowItem | null>(null);
  const [sortOrder, setSortOrder] = useState<SortOrder>('ascend');
  const [page, setPage] = useState(1);
  const totalPages = Math.ceil(apiData.total / perPage) || 1;

  const fetchData = useCallback(async () => {
    try {
      const queryParams = new URLSearchParams();
      queryParams.append('page', `${page}`);
      queryParams.append('perPage', `${perPage}`);
      if (search) queryParams.append('search', search);
      if (sortKey) {
        queryParams.append('sortKey', sortKey);
        queryParams.append('sortOrder', sortOrder);
      }

      const response = await fetch(`${API_BASE_URL}${CSV_LIST_PATH}?${queryParams.toString()}`);

      if (!response.ok) throw new Error('Failed to fetch data');
      const result = await response.json();
      setData(result);
    } catch (error) {
      alert('Error fetching data: ' + JSON.stringify(error));
    }
  }, [page, search, sortKey, sortOrder]);

  const handleUpload: React.InputHTMLAttributes<HTMLInputElement>['onChange'] = async event => {
    const file = event.target.files?.[0];
    if (!file) return;

    try {
      const formData = new FormData();
      formData.append('file', file);

      const response = await fetch(`${API_BASE_URL}${CSV_UPLOAD_PATH}`, {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) throw new Error('Upload failed');

      alert('CSV uploaded and imported successfully!');
      fetchData();
    } catch (error) {
      alert('Error uploading data: ' + JSON.stringify(error));
    }
  };

  useEffect(() => {
    fetchData();
  }, [search, sortKey, sortOrder, page, fetchData]);

  const handleSearch = (value?: string) => {
    setSearch(value || '');
    setPage(1);
  };

  const handleSort = (key: keyof RowItem | null) => {
    const order = sortKey === key && sortOrder === 'asc' ? 'desc' : 'asc';
    setSortKey(key);
    setSortOrder(order);
    setPage(1);
  };

  const handlePageChange = (newPage: number) => {
    setPage(newPage);
  };
  const searchRef = useRef<HTMLInputElement>(null);
  return (
    <div style={{ margin: 10 }}>
      <input type="file" accept=".csv" onChange={handleUpload} />
      <input ref={searchRef} placeholder="Search" style={{ margin: '10px' }} />
      <button
        onClick={() => {
          handleSearch(searchRef.current?.value);
        }}
      >
        Search
      </button>
      <table width="100%" style={{ marginTop: 20, borderCollapse: 'collapse' }}>
        <thead>
          <tr>
            {columns.map(col => (
              <th
                style={{ padding: '10px 16px', border: '1px solid #fefefe' }}
                key={col}
                onClick={() => handleSort(col)}
              >
                {col.replace('_', ' ').toUpperCase()}{' '}
                {sortKey === col ? (sortOrder === 'ascend' ? '▲' : '▼') : ''}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {apiData.data.length ? (
            apiData.data.map((item, index) => (
              <tr key={index}>
                {columns.map(c => {
                  const value = item?.[c];
                  return (
                    <td style={{ padding: '10px 16px' }} key={c}>
                      {value || '-'}
                    </td>
                  );
                })}
              </tr>
            ))
          ) : (
            <tr>
              <td style={{ padding: '10px 16px' }} align="center" colSpan={columns.length}>
                <h2>No Data</h2>
              </td>
            </tr>
          )}
        </tbody>
      </table>
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: 20,
          justifyContent: 'flex-end',
        }}
      >
        <button disabled={page === 1} onClick={() => handlePageChange(page - 1)}>
          Previous
        </button>
        <span> Page {page} </span>
        <button disabled={totalPages === page} onClick={() => handlePageChange(page + 1)}>
          Next
        </button>
      </div>
    </div>
  );
};

export default CsvImporter;

/*
    Copyright (C) 2005-2007 Tom Beaumont

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/


struct PackFile1
{
	class Entry {
		int len;
	public:
		char name[1];

		Entry* GetNext()
		{
			return (Entry*)((char*)name + len);
		}

		void* Data()
		{
			char* pos = name;
			while (*pos!=0)
				pos++;
			return pos+1;
		}

		int DataLen()
		{
			return len - strlen(name) - 1;
		}
	};

	int numfiles;
	Entry** e;
	void* data;

	PackFile1() : e(0), data(0), numfiles(0)
	{}

	Entry* Find(const char* name)
	{
		if (numfiles==0) return 0;
		int a=0, b=numfiles;
		while (b>a)
		{
			const int mid = (a+b)>>1;
			int diff = strcmp(name, e[mid]->name);
			if (diff==0)
				return e[mid];
			else if (diff < 0)
				b=mid;
			else
				a=mid+1;
		}
		return 0;
	}

	void Read(FILE* f)
	{
		if (numfiles || e || data)
			FATAL("Calling Packfile1::Read when already initialised.");

		int size;
		fseek(f, -(int)sizeof(size), SEEK_END);
		int end_offset = ftell(f);
		fread(&size, sizeof(size), 1, f);
		fseek(f, end_offset - size, SEEK_SET);

		data = malloc(size);
		char* data_end = (char*)data + size;
		fread(data, 1, size, f);

		numfiles=0;
		Entry* i = (Entry*)data;
		while ((void*)i < data_end)
		{
			numfiles++;
			i = i->GetNext();
		}
		
		e = new Entry* [numfiles];

		i = (Entry*)data;
		for (int j=0; j<numfiles; j++, i = i->GetNext())
			e[j] = i;
	}

	~PackFile1()
	{
		free(data);
	}

};

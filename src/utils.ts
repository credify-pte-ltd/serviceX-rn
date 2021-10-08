const toCamel = (s: string): string => {
  return s.replace(/([-_][a-z])/gi, ($1) => {
    return $1.toUpperCase().replace('-', '').replace('_', '');
  });
};

const isArray = (a: any): boolean => {
  return Array.isArray(a);
};

const isObject = (o: any): boolean => {
  return o === Object(o) && !isArray(o) && typeof o !== 'function';
};

export const camelize = (o: any): any => {
  if (isObject(o)) {
    const n = {};

    Object.keys(o).forEach((k) => {
      // @ts-ignore
      n[toCamel(k)] = camelize(o[k]);
    });
    return n;
  } else if (isArray(o)) {
    return o.map((i: any) => {
      return camelize(i);
    });
  }

  return o;
};

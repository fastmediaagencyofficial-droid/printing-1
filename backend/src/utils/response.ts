import { Response } from 'express';

// ─── STANDARD RESPONSE HELPERS ───────────────────────────────────────────────
export const sendSuccess = (
  res: Response,
  data: any = null,
  message = 'Success',
  statusCode = 200,
  pagination?: object
): Response => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    ...(pagination && { pagination }),
  });
};

export const sendError = (
  res: Response,
  statusCode = 500,
  message = 'Something went wrong',
  code = 'ERROR',
  errors?: any[]
): Response => {
  return res.status(statusCode).json({
    success: false,
    message,
    code,
    ...(errors && { errors }),
  });
};

export const sendCreated = (res: Response, data: any, message = 'Created successfully'): Response =>
  sendSuccess(res, data, message, 201);

export const sendNotFound = (res: Response, message = 'Resource not found'): Response =>
  sendError(res, 404, message, 'NOT_FOUND');

export const sendUnauthorized = (res: Response, message = 'Unauthorized'): Response =>
  sendError(res, 401, message, 'UNAUTHORIZED');

export const sendForbidden = (res: Response, message = 'Forbidden'): Response =>
  sendError(res, 403, message, 'FORBIDDEN');

export const sendBadRequest = (res: Response, message: string, errors?: any[]): Response =>
  sendError(res, 400, message, 'BAD_REQUEST', errors);

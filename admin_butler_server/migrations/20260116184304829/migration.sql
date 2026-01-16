BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "document" ADD COLUMN "draft" text;
ALTER TABLE "document" ADD COLUMN "replyDraft" text;

--
-- MIGRATION VERSION FOR admin_butler
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('admin_butler', '20260116184304829', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260116184304829', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();


COMMIT;
